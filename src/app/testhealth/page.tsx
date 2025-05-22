import React from 'react';

export default function TestHealth() {
    return (
        <div> 
            <button onClick={() => {
                fetch('/api/auth/health')
                    .then(res => res.json())
                    .then(data => 
                        <p>
                            {data.status} {data.message}
                        </p>
                    )
            }}> Check health </button>
        </div>
    )
}